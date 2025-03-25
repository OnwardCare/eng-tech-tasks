/**
 * @jest-environment jsdom
 */

import * as React from 'react';
import { act } from "react";
import renderer from 'react-test-renderer';
import {cleanup, fireEvent, render} from '@testing-library/react';
import Index from '..';

afterEach(cleanup);

it(`renders correctly`, () => {
  act(() => {
    const {getByText, getByLabelText} = render(<Index/>)
    expect(getByText(/Edit/i)).toBeTruthy();

  });

});
 